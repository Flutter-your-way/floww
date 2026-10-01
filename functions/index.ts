import express, {Application, RequestHandler} from "express";
import {logger} from "firebase-functions";
import {onRequest} from "firebase-functions/https";
import morgan from "morgan";
import {openAiApiKey, usdaApiKey} from "./src/constants/secrets";
import {handleDeleteAccount} from "./src/handlers/account.handler";
import {
  handleDescribeFood,
  handleScanFood,
  handleSearchFood,
} from "./src/handlers/food.handler";
import {
  handleAnalyzeOnboarding,
  handleCompleteOnboarding,
  handleSubmitOnboarding,
} from "./src/handlers/onboarding.handler";
import {
  handleCancelSubscription,
  handleSubscribe,
} from "./src/handlers/premium.handler";
import {handleFoodImage} from "./src/handlers/food.image.handler";
import {handleDailyQuote} from "./src/handlers/quote.handler";
import {handleWaveChat} from "./src/handlers/wave.handler";
import {
  handleCompleteWorkout,
  handleGenerateWorkoutPlan,
  handleUnlogWorkout,
} from "./src/handlers/workout.handler";
import {authenticate} from "./src/middlewares/auth.middleware";
import {
  errorHandler,
  notFoundHandler,
} from "./src/middlewares/error.middleware";

export {
  onFoodLogWritten,
  onHabitLogWritten,
  onHabitWritten,
  onWaterLogWritten,
  onWorkoutSessionWritten,
} from "./src/triggers/activity.trigger";
export {
  onOnboardingDetailsWritten,
  onWeightLogWritten,
} from "./src/triggers/profile.trigger";
export {onHealthLogWritten} from "./src/triggers/health.trigger";
export {expireSubscriptions} from "./src/scheduled/subscriptions.schedule";
export {sendScheduledReminders} from "./src/scheduled/reminders.schedule";

type HttpMethod = "get" | "post" | "delete";

const ANY_PATH = /.*/;

const createApp = (
  method: HttpMethod,
  handler: RequestHandler,
  {requireAuth = true}: {requireAuth?: boolean} = {},
): Application => {
  const app = express();

  app.use(express.json({limit: "10mb"}));
  app.use(morgan("combined", {
    stream: {
      write: (message) => logger.info("HTTP request", {
        requestLog: message.trim(),
      }),
    },
  }));

  if (requireAuth) {
    app[method](ANY_PATH, authenticate, handler);
  } else {
    app[method](ANY_PATH, handler);
  }

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
};

export const scanFood = onRequest(
  {
    cors: true,
    secrets: [openAiApiKey],
    memory: "512MiB",
    timeoutSeconds: 150,
  },
  createApp("post", handleScanFood),
);

export const searchFood = onRequest(
  {
    cors: true,
    secrets: [usdaApiKey],
    memory: "256MiB",
    timeoutSeconds: 30,
  },
  createApp("post", handleSearchFood),
);

export const describeFood = onRequest(
  {
    cors: true,
    secrets: [openAiApiKey],
    memory: "512MiB",
    timeoutSeconds: 120,
  },
  createApp("post", handleDescribeFood),
);

export const foodImage = onRequest(
  {
    cors: true,
    memory: "256MiB",
    timeoutSeconds: 30,
  },
  createApp("post", handleFoodImage),
);

export const waveChat = onRequest(
  {
    cors: true,
    secrets: [openAiApiKey],
    memory: "512MiB",
    timeoutSeconds: 120,
  },
  createApp("post", handleWaveChat),
);

export const deleteAccount = onRequest(
  {
    cors: true,
    memory: "256MiB",
    timeoutSeconds: 300,
  },
  createApp("delete", handleDeleteAccount),
);

const lightOptions = {
  cors: true,
  memory: "256MiB" as const,
  timeoutSeconds: 60,
};

export const completeWorkout = onRequest(
  lightOptions,
  createApp("post", handleCompleteWorkout),
);

export const unlogWorkout = onRequest(
  lightOptions,
  createApp("post", handleUnlogWorkout),
);

export const generateWorkoutPlan = onRequest(
  {
    cors: true,
    secrets: [openAiApiKey],
    memory: "512MiB",
    timeoutSeconds: 120,
  },
  createApp("post", handleGenerateWorkoutPlan),
);

export const submitOnboarding = onRequest(
  lightOptions,
  createApp("post", handleSubmitOnboarding),
);

export const analyzeOnboarding = onRequest(
  {
    cors: true,
    secrets: [openAiApiKey],
    memory: "512MiB",
    timeoutSeconds: 120,
  },
  createApp("post", handleAnalyzeOnboarding),
);

export const dailyQuote = onRequest(
  lightOptions,
  createApp("post", handleDailyQuote),
);

export const completeOnboarding = onRequest(
  lightOptions,
  createApp("post", handleCompleteOnboarding),
);

export const subscribePremium = onRequest(
  lightOptions,
  createApp("post", handleSubscribe),
);

export const cancelPremium = onRequest(
  lightOptions,
  createApp("post", handleCancelSubscription),
);

