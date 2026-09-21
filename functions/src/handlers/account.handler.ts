import {Request, Response} from "express";
import {getAuth} from "firebase-admin/auth";
import {logger} from "firebase-functions";
import {ApiError, sendData} from "../common/api.error";
import {
  aiUsageCollection,
  firestore,
  onboardingDetailsCollection,
  usersCollection,
} from "../constants/collections";

const AUTH_USER_NOT_FOUND = "auth/user-not-found";

export const handleDeleteAccount = async (req: Request, res: Response) => {
  const uid = req.user.uid;

  try {
    await firestore.recursiveDelete(usersCollection.doc(uid));
    await onboardingDetailsCollection.doc(uid).delete();

    const usage = await aiUsageCollection.where("userId", "==", uid).get();
    await Promise.all(usage.docs.map((doc) => doc.ref.delete()));
  } catch (error) {
    logger.error("handleDeleteAccount: data wipe failed", {uid, error});
    throw new ApiError("INTERNAL", "Could not delete your data.");
  }

  try {
    await getAuth().deleteUser(uid);
  } catch (error) {
    const code = (error as {code?: string}).code;
    if (code !== AUTH_USER_NOT_FOUND) {
      logger.error("handleDeleteAccount: auth delete failed", {uid, error});
      throw new ApiError("INTERNAL", "Could not delete your account.");
    }
  }

  sendData(res, {deleted: true});
};
