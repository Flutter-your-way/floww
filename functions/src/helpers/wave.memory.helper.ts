import {DocumentData} from "firebase-admin/firestore";
import {normalizeText, recordOf} from "../common/utils";
import {
  MAX_WAVE_MEMORIES,
  MAX_WAVE_MEMORY_FORGETS,
  MAX_WAVE_MEMORY_LENGTH,
  MAX_WAVE_MEMORY_WRITES,
  MAX_WAVE_PROMPT_MEMORIES,
  MAX_WAVE_SUMMARY_ITEMS,
  MAX_WAVE_SUMMARY_ITEM_LENGTH,
} from "../constants/ai.constants";
import {
  SETTINGS_DOC,
  USER_COLLECTIONS,
  WAVE_SUMMARY_DOC,
  firestore,
  userCollection,
} from "../constants/collections";
import {
  WaveMemoryCategory,
  WaveMemoryUpdate,
  WaveSummaryItem,
  WaveSummarySection,
  waveMemoryCategorySchema,
  waveSummaryItemSchema,
} from "../models/wave.model";

const LABEL_PREFIX = "M";
const MIN_WORD_LENGTH = 3;
const SETTINGS_GROUP = "wave";
const MEMORY_FLAG = "memory";

export interface WaveMemoryNoteDoc {
  id: string;
  text: string;
  category: WaveMemoryCategory;
  updatedAt: string;
}

export interface LabeledMemory extends WaveMemoryNoteDoc {
  label: string;
}

export interface WaveMemory {
  enabled: boolean;
  notes: WaveMemoryNoteDoc[];
  summary: string;
}

export interface WaveMemoryChanges {
  saved: string[];
  forgotten: string[];
}

export const EMPTY_MEMORY_UPDATE: WaveMemoryUpdate = {remember: [], forget: []};

export const memoriesCollection = (uid: string) =>
  userCollection(uid, USER_COLLECTIONS.waveMemories);

export const summaryDoc = (uid: string) =>
  userCollection(uid, USER_COLLECTIONS.waveState).doc(WAVE_SUMMARY_DOC);

export const isMemoryEnabled = (settings: DocumentData | undefined) =>
  recordOf(settings?.[SETTINGS_GROUP])[MEMORY_FLAG] !== false;

export const loadMemoryEnabled = async (uid: string): Promise<boolean> =>
  isMemoryEnabled(
    (await userCollection(uid, USER_COLLECTIONS.settings)
      .doc(SETTINGS_DOC)
      .get()).data(),
  );

const SUMMARY_LABELS: Record<WaveSummarySection, string> = {
  ongoing: "Ongoing",
  agreed: "Agreed",
  open: "Follow up",
};

const cleanItemText = (text: string): string =>
  text.trim().replace(/^[-•]\s*/, "").replace(/\s+/g, " ")
    .slice(0, MAX_WAVE_SUMMARY_ITEM_LENGTH);

export const sanitizeSummaryItems = (items: unknown): WaveSummaryItem[] => {
  const seen = new Set<string>();
  return (Array.isArray(items) ? items : [])
    .flatMap((item) => {
      const parsed = waveSummaryItemSchema.safeParse(item);
      if (!parsed.success) return [];
      const {section, text} = parsed.data;
      return [{section, text: cleanItemText(text)}];
    })
    .filter((item) => {
      const key = normalizeText(item.text);
      if (key.length === 0 || seen.has(key)) return false;
      seen.add(key);
      return true;
    })
    .slice(0, MAX_WAVE_SUMMARY_ITEMS);
};

export const renderSummaryItems = (items: WaveSummaryItem[]): string =>
  items
    .map((item) => `- ${SUMMARY_LABELS[item.section]}: ${item.text}`)
    .join("\n");

export const summaryTextOf = (data: DocumentData | undefined): string => {
  if (Array.isArray(data?.items)) {
    return renderSummaryItems(sanitizeSummaryItems(data?.items));
  }
  return typeof data?.summary === "string" ? data.summary.trim() : "";
};

const categoryOf = (value: unknown): WaveMemoryCategory => {
  const parsed = waveMemoryCategorySchema.safeParse(value);
  return parsed.success ? parsed.data : "life";
};

const noteOf = (id: string, data: DocumentData): WaveMemoryNoteDoc | null => {
  const text = typeof data.text === "string" ? data.text.trim() : "";
  if (text.length === 0) return null;
  return {
    id,
    text,
    category: categoryOf(data.category),
    updatedAt: typeof data.updatedAt === "string" ? data.updatedAt : "",
  };
};

export const loadWaveMemory = async (uid: string): Promise<WaveMemory> => {
  if (!(await loadMemoryEnabled(uid))) {
    return {enabled: false, notes: [], summary: ""};
  }

  const [notes, summary] = await Promise.all([
    memoriesCollection(uid)
      .orderBy("updatedAt", "desc")
      .limit(MAX_WAVE_MEMORIES)
      .get(),
    summaryDoc(uid).get(),
  ]);

  return {
    enabled: true,
    notes: notes.docs
      .map((doc) => noteOf(doc.id, doc.data()))
      .filter((note): note is WaveMemoryNoteDoc => note !== null),
    summary: summaryTextOf(summary.data()),
  };
};

const wordsOf = (text: string): Set<string> =>
  new Set(normalizeText(text)
    .split(/[^a-z0-9]+/)
    .filter((word) => word.length >= MIN_WORD_LENGTH));

export const selectMemories = (
  notes: WaveMemoryNoteDoc[],
  conversation: string,
): LabeledMemory[] => {
  const words = wordsOf(conversation);
  return notes
    .map((note, recency) => {
      let overlap = 0;
      for (const word of wordsOf(note.text)) {
        if (words.has(word)) overlap++;
      }
      return {note, overlap, recency};
    })
    .sort((a, b) => b.overlap - a.overlap || a.recency - b.recency)
    .slice(0, MAX_WAVE_PROMPT_MEMORIES)
    .map(({note}, index) => ({...note, label: `${LABEL_PREFIX}${index + 1}`}));
};

const cleanText = (text: string): string =>
  text.trim().replace(/\s+/g, " ").slice(0, MAX_WAVE_MEMORY_LENGTH);

export const sanitizeMemoryUpdate = (
  update: WaveMemoryUpdate | undefined,
): WaveMemoryUpdate => {
  if (!update) return EMPTY_MEMORY_UPDATE;
  return {
    remember: update.remember
      .map((note) => ({
        text: cleanText(note.text),
        category: categoryOf(note.category),
        replaces: note.replaces.trim().toUpperCase(),
      }))
      .filter((note) => note.text.length > 0)
      .slice(0, MAX_WAVE_MEMORY_WRITES),
    forget: update.forget
      .map((label) => label.trim().toUpperCase())
      .filter((label) => label.length > 0)
      .slice(0, MAX_WAVE_MEMORY_FORGETS),
  };
};

export const applyMemoryUpdate = async (
  uid: string,
  memory: WaveMemory,
  labeled: LabeledMemory[],
  update: WaveMemoryUpdate,
): Promise<WaveMemoryChanges> => {
  const changes: WaveMemoryChanges = {saved: [], forgotten: []};
  if (!memory.enabled) return changes;
  if (update.remember.length === 0 && update.forget.length === 0) {
    return changes;
  }

  const byLabel = new Map(labeled.map((note) => [note.label, note]));
  const byText = new Map(memory.notes.map((note) =>
    [normalizeText(note.text), note]));
  const removed = new Set<string>();
  const touched = new Set<string>();
  const now = new Date().toISOString();
  const batch = firestore.batch();
  const collection = memoriesCollection(uid);
  let added = 0;

  for (const label of update.forget) {
    const note = byLabel.get(label);
    if (!note || removed.has(note.id)) continue;
    batch.delete(collection.doc(note.id));
    removed.add(note.id);
    changes.forgotten.push(note.text);
  }

  for (const note of update.remember) {
    const target = byLabel.get(note.replaces) ??
      byText.get(normalizeText(note.text));
    if (target && !removed.has(target.id)) {
      touched.add(target.id);
      batch.set(collection.doc(target.id), {
        text: note.text,
        category: note.category,
        updatedAt: now,
      }, {merge: true});
      if (normalizeText(target.text) !== normalizeText(note.text)) {
        changes.saved.push(note.text);
      }
      continue;
    }
    batch.set(collection.doc(), {
      text: note.text,
      category: note.category,
      source: "wave",
      createdAt: now,
      updatedAt: now,
    });
    added++;
    changes.saved.push(note.text);
  }

  const kept = memory.notes.filter((note) => !removed.has(note.id));
  const overflow = kept.length + added - MAX_WAVE_MEMORIES;
  if (overflow > 0) {
    kept
      .filter((note) => !touched.has(note.id))
      .slice(-overflow)
      .forEach((note) => batch.delete(collection.doc(note.id)));
  }

  await batch.commit();
  return changes;
};
