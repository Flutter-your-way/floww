import express, {Application, RequestHandler} from "express";
import {logger} from "firebase-functions";
import {onRequest} from "firebase-functions/https";
import morgan from "morgan";
import {openAiApiKey} from "./src/constants/secrets";
import {handleDeleteAccount} from "./src/handlers/account.handler";
import {handleScanFood} from "./src/handlers/food.handler";
import {authenticate} from "./src/middlewares/auth.middleware";
import {
  errorHandler,
  notFoundHandler,
} from "./src/middlewares/error.middleware";

type HttpMethod = "post" | "delete";

const ANY_PATH = /.*/;

const createApp = (
  method: HttpMethod,
  handler: RequestHandler,
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

  app[method](ANY_PATH, authenticate, handler);

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

export const deleteAccount = onRequest(
  {
    cors: true,
    memory: "256MiB",
    timeoutSeconds: 300,
  },
  createApp("delete", handleDeleteAccount),
);
