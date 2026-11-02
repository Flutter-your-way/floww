import {Request, Response} from "express";
import {logger} from "firebase-functions";
import {sendData} from "../common/api.error";
import {EXERCISE_VIDEO_DAILY_LIMIT} from "../constants/ymove.constants";
import {
  readCachedVideo,
  writeCachedVideo,
} from "../helpers/exercise.video.cache.helper";
import {releaseAiQuota, reserveAiQuota} from "../helpers/usage.helper";
import {fetchYmoveVideo, findYmoveSlug} from "../helpers/ymove.helper";
import {exerciseVideoValidator} from "../validators/exercise.video.validator";

export const handleExerciseVideo = async (req: Request, res: Response) => {
  const request = exerciseVideoValidator.parse(req.body);
  const uid = req.user.uid;

  const cached = await readCachedVideo(request);
  if (cached?.video) {
    sendData(res, {video: cached.video});
    return;
  }
  if (cached?.isMatchFresh && cached.slug === null) {
    sendData(res, {video: null});
    return;
  }

  await reserveAiQuota(uid, "exerciseVideo", EXERCISE_VIDEO_DAILY_LIMIT);

  const reuseMatch = cached?.isMatchFresh === true;
  let slug;
  let video;
  try {
    slug = reuseMatch ? cached.slug : await findYmoveSlug(request);
    video = slug ? await fetchYmoveVideo(slug) : null;
  } catch (error) {
    await releaseAiQuota(uid, "exerciseVideo").catch((releaseError) =>
      logger.error("handleExerciseVideo: quota release failed", {
        releaseError,
      }));
    throw error;
  }

  const matchedAt = reuseMatch ? cached.matchedAt : new Date().toISOString();
  await writeCachedVideo(request, slug, video, matchedAt);
  sendData(res, {video});
};
