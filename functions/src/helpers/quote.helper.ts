import {logger} from "firebase-functions";
import {hashKey} from "../common/utils";
import {dailyQuotesCollection} from "../constants/collections";

export interface DailyQuote {
  text: string;
  author: string;
}

const QUOTES_URL = "https://zenquotes.io/api/quotes";
const FETCH_TIMEOUT_MS = 5000;
const MAX_QUOTE_LENGTH = 90;
const MIN_QUOTE_LENGTH = 12;
const PLACEHOLDER_AUTHOR = "zenquotes.io";
const ALREADY_EXISTS = 6;

const FALLBACK_QUOTES: DailyQuote[] = [
  {text: "Small steps every day add up to big results.", author: "Unknown"},
  {
    text: "Discipline is choosing what you want most.",
    author: "Abraham Lincoln",
  },
  {text: "The body achieves what the mind believes.", author: "Napoleon Hill"},
  {text: "Energy flows where attention goes.", author: "Tony Robbins"},
  {text: "Well done is better than well said.", author: "Benjamin Franklin"},
  {
    text: "It always seems impossible until it's done.",
    author: "Nelson Mandela",
  },
  {text: "Motion is lotion.", author: "Unknown"},
  {text: "Rest is part of the training.", author: "Unknown"},
  {text: "What we do every day matters most.", author: "Gretchen Rubin"},
  {
    text: "Take care of your body. It's the only place you have to live.",
    author: "Jim Rohn",
  },
  {
    text: "Strength does not come from winning.",
    author: "Arnold Schwarzenegger",
  },
  {text: "Nothing will work unless you do.", author: "Maya Angelou"},
  {text: "Slow progress is still progress.", author: "Unknown"},
  {text: "Be stronger than your excuses.", author: "Unknown"},
];

const fallbackFor = (day: string): DailyQuote => {
  const index = parseInt(hashKey(day).slice(0, 8), 16) %
    FALLBACK_QUOTES.length;
  return FALLBACK_QUOTES[index];
};

const isUsable = (quote: DailyQuote): boolean =>
  quote.text.length >= MIN_QUOTE_LENGTH &&
  quote.text.length <= MAX_QUOTE_LENGTH &&
  quote.author.length > 0 &&
  quote.author !== PLACEHOLDER_AUTHOR;

const fetchShortQuote = async (): Promise<DailyQuote | null> => {
  const response = await fetch(QUOTES_URL, {
    signal: AbortSignal.timeout(FETCH_TIMEOUT_MS),
  });
  if (!response.ok) return null;
  const body: unknown = await response.json();
  if (!Array.isArray(body)) return null;
  const quotes = body
    .map((item): DailyQuote => ({
      text: typeof item?.q === "string" ? item.q.trim() : "",
      author: typeof item?.a === "string" ? item.a.trim() : "",
    }))
    .filter(isUsable);
  return quotes[0] ?? null;
};

export const dailyQuoteFor = async (day: string): Promise<DailyQuote> => {
  const ref = dailyQuotesCollection.doc(day);
  const cached = await ref.get();
  if (cached.exists) {
    return {text: cached.get("text"), author: cached.get("author")};
  }

  let quote: DailyQuote | null = null;
  try {
    quote = await fetchShortQuote();
  } catch (error) {
    logger.warn("dailyQuoteFor: quote fetch failed", {error});
  }
  if (!quote) return fallbackFor(day);

  try {
    await ref.create({...quote, createdAt: new Date().toISOString()});
    return quote;
  } catch (error) {
    if ((error as {code?: number}).code !== ALREADY_EXISTS) throw error;
    const stored = await ref.get();
    return {text: stored.get("text"), author: stored.get("author")};
  }
};
