import {z} from "zod";

export const exerciseVideoSchema = z.object({
  slug: z.string(),
  title: z.string(),
  videoUrl: z.string(),
  hlsUrl: z.string().nullable(),
  thumbnailUrl: z.string().nullable(),
  isPortrait: z.boolean(),
  expiresAt: z.string(),
});

export type ExerciseVideo = z.infer<typeof exerciseVideoSchema>;
