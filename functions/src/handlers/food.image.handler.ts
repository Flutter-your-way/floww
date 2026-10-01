import {Request, Response} from "express";
import {logger} from "firebase-functions";
import {sendData} from "../common/api.error";
import {FOOD_IMAGE_DAILY_LIMIT} from "../constants/food.image.constants";
import {
  foodImageQueryOf,
  readCachedFoodImage,
  searchFoodImage,
  writeCachedFoodImage,
} from "../helpers/food.image.helper";
import {releaseAiQuota, reserveAiQuota} from "../helpers/usage.helper";
import {foodImageValidator} from "../validators/food.image.validator";

export const handleFoodImage = async (req: Request, res: Response) => {
  const {name} = foodImageValidator.parse(req.body);
  const uid = req.user.uid;
  const query = foodImageQueryOf(name);

  const cached = await readCachedFoodImage(query);
  if (cached) {
    sendData(res, cached);
    return;
  }

  await reserveAiQuota(uid, "foodImage", FOOD_IMAGE_DAILY_LIMIT);

  let url: string | null;
  try {
    url = await searchFoodImage(query);
  } catch (error) {
    await releaseAiQuota(uid, "foodImage").catch((releaseError) =>
      logger.error("handleFoodImage: quota release failed", {releaseError}));
    throw error;
  }

  await writeCachedFoodImage(query, url);
  sendData(res, {url});
};
