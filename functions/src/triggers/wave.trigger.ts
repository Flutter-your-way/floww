import {logger} from "firebase-functions";
import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/firestore";
import {openAiApiKey} from "../constants/secrets";
import {
  isRatingChange,
  recordWaveRating,
} from "../helpers/wave.rating.helper";
import {
  isConversationTurn,
  refreshWaveSummary,
} from "../helpers/wave.summary.helper";

export const onWaveMessageCreated = onDocumentCreated(
  {document: "users/{uid}/wave_messages/{messageId}", secrets: [openAiApiKey]},
  async (event) => {
    if (!isConversationTurn(event.data?.data())) return;
    const uid = event.params.uid;
    await refreshWaveSummary(uid).catch((error) =>
      logger.error("onWaveMessageCreated: summary failed", {uid, error}));
  },
);

export const onWaveMessageRated = onDocumentUpdated(
  "users/{uid}/wave_messages/{messageId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!after || !isRatingChange(before, after)) return;
    const {uid, messageId} = event.params;
    await recordWaveRating(uid, messageId, after).catch((error) =>
      logger.error("onWaveMessageRated: rating failed", {uid, error}));
  },
);
