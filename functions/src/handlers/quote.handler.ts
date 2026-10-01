import {Request, Response} from "express";
import {ApiError, sendData} from "../common/api.error";
import {dailyQuoteFor} from "../helpers/quote.helper";
import {clockOf, loadActiveUser} from "../helpers/user.clock.helper";

export const handleDailyQuote = async (req: Request, res: Response) => {
  const user = await loadActiveUser(req.user.uid);
  if (!user) throw new ApiError("UNAUTHORIZED", "Please sign in again.");
  const {today} = clockOf(user);
  const quote = await dailyQuoteFor(today);
  sendData(res, {...quote, date: today});
};
