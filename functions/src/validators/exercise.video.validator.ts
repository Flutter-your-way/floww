import {z} from "zod";
import {
  EXERCISE_VIDEO_KINDS,
  MAX_EXERCISE_VIDEO_QUERIES,
  MAX_EXERCISE_VIDEO_QUERY_LENGTH,
  MIN_EXERCISE_VIDEO_QUERY_LENGTH,
} from "../constants/ymove.constants";

export const exerciseVideoValidator = z.object({
  kind: z.enum(EXERCISE_VIDEO_KINDS),
  queries: z.array(
    z.string().trim()
      .min(MIN_EXERCISE_VIDEO_QUERY_LENGTH)
      .max(MAX_EXERCISE_VIDEO_QUERY_LENGTH),
  ).min(1).max(MAX_EXERCISE_VIDEO_QUERIES),
});

export type ExerciseVideoRequest = z.infer<typeof exerciseVideoValidator>;
