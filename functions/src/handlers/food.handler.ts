import {Request, Response} from "express";
import {logger} from "firebase-functions";
import {ApiError, sendData} from "../common/api.error";
import {
  FOOD_DESCRIBE_DAILY_LIMIT,
  FOOD_DESCRIBE_MODEL,
  FOOD_DESCRIBE_PROMPT_VERSION,
  FOOD_SCAN_DAILY_LIMIT,
  FOOD_SCAN_MODEL,
  FOOD_SCAN_PROMPT_VERSION,
} from "../constants/ai.constants";
import {foodLogsCollection} from "../constants/collections";
import {FOOD_SEARCH_DAILY_LIMIT} from "../constants/usda.constants";
import {
  analyzeFoodImage,
  analyzeFoodText,
} from "../helpers/food.analysis.helper";
import {
  readCachedDescription,
  readCachedSearch,
  writeCachedDescription,
  writeCachedSearch,
} from "../helpers/food.cache.helper";
import {toAiApiError} from "../helpers/openai.helper";
import {
  recordAiTokens,
  releaseAiQuota,
  reserveAiQuota,
} from "../helpers/usage.helper";
import {searchUsdaFoods} from "../helpers/usda.helper";
import {
  FoodAnalysis,
  FoodModel,
  foodModelSchema,
} from "../models/food.model";
import {describeFoodValidator} from "../validators/describe.food.validator";
import {scanFoodValidator} from "../validators/scan.food.validator";
import {searchFoodValidator} from "../validators/search.food.validator";

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

export const handleSearchFood = async (req: Request, res: Response) => {
  const {query} = searchFoodValidator.parse(req.body);
  const uid = req.user.uid;

  const cached = await readCachedSearch(query);
  if (cached) {
    sendData(res, cached);
    return;
  }

  await reserveAiQuota(uid, "foodSearch", FOOD_SEARCH_DAILY_LIMIT);

  let foods;
  try {
    foods = await searchUsdaFoods(query);
  } catch (error) {
    await releaseAiQuota(uid, "foodSearch").catch((releaseError) =>
      logger.error("handleSearchFood: quota release failed", {releaseError}));
    throw error;
  }

  await writeCachedSearch(query, foods);
  sendData(res, foods);
};

const describeAnalysis = async (
  uid: string,
  text: string,
): Promise<FoodAnalysis> => {
  const cached = await readCachedDescription(text);
  if (cached) return cached;

  await reserveAiQuota(uid, "foodDescribe", FOOD_DESCRIBE_DAILY_LIMIT);

  let result;
  try {
    result = await analyzeFoodText({text});
  } catch (error) {
    await releaseAiQuota(uid, "foodDescribe").catch((releaseError) =>
      logger.error("handleDescribeFood: quota release failed", {releaseError}));
    throw toAiApiError(error, "handleDescribeFood");
  }

  await recordAiTokens(uid, "foodDescribe", result.usage).catch(
    (usageError) => logger.error(
      "handleDescribeFood: token usage write failed", {usageError}));

  if (result.analysis.isFood) {
    await writeCachedDescription(text, result.analysis);
  }
  return result.analysis;
};

export const handleDescribeFood = async (req: Request, res: Response) => {
  const {text} = describeFoodValidator.parse(req.body);
  const uid = req.user.uid;

  const {isFood, ...analysis} = await describeAnalysis(uid, text);
  if (!isFood) {
    throw new ApiError("NOT_FOOD", "WAVE couldn't find any food in that.");
  }

  const food: FoodModel = foodModelSchema.parse({
    ...analysis,
    id: foodLogsCollection(uid).doc().id,
    userId: uid,
    source: "described",
    aiModel: FOOD_DESCRIBE_MODEL,
    promptVersion: FOOD_DESCRIBE_PROMPT_VERSION,
    createdAt: new Date().toISOString(),
  });

  sendData(res, food);
};
