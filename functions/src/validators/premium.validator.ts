import {z} from "zod";

export const subscribeValidator = z.object({
  term: z.enum(["monthly", "yearly"]),
});
