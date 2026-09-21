import {Request, Response} from "express";
import {logger} from "firebase-functions";
import {ApiError, sendData} from "../common/api.error";
import {
  FOOD_SCAN_DAILY_LIMIT,
  FOOD_SCAN_MODEL,
  FOOD_SCAN_PROMPT_VERSION,
} from "../constants/ai.constants";
import {foodLogsCollection} from "../constants/collections";
import {analyzeFoodImage} from "../helpers/food.analysis.helper";
import {toAiApiError} from "../helpers/openai.helper";
import {
  recordAiTokens,
  releaseAiQuota,
  reserveAiQuota,
} from "../helpers/usage.helper";
import {FoodModel, foodModelSchema} from "../models/food.model";
import {scanFoodValidator} from "../validators/scan.food.validator";

export const handleScanFood = async (req: Request, res: Response) => {
  const body = scanFoodValidator.parse(req.body);
  const uid = req.user.uid;

  await reserveAiQuota(uid, "foodScan", FOOD_SCAN_DAILY_LIMIT);

  let result;
  try {
    result = await analyzeFoodImage(body);
  } catch (error) {
    await releaseAiQuota(uid, "foodScan").catch((releaseError) =>
      logger.error("handleScanFood: quota release failed", {releaseError}));
    throw toAiApiError(error, "handleScanFood");
  }

  await recordAiTokens(uid, "foodScan", result.usage).catch((usageError) =>
    logger.error("handleScanFood: token usage write failed", {usageError}));

  const {isFood, ...analysis} = result.analysis;
  if (!isFood) {
    throw new ApiError("NOT_FOOD", "No food detected in this photo.");
  }

  const food: FoodModel = foodModelSchema.parse({
    ...analysis,
    id: foodLogsCollection(uid).doc().id,
    userId: uid,
    source: "scan",
    aiModel: FOOD_SCAN_MODEL,
    promptVersion: FOOD_SCAN_PROMPT_VERSION,
    createdAt: new Date().toISOString(),
  });

  sendData(res, food);
};
