import {WAVE_CHAT_ROUTES} from "../constants/ai.constants";
import {WaveIntent, WaveRoute} from "../models/wave.model";

export type WaveRouteConfig = typeof WAVE_CHAT_ROUTES[WaveRoute];

const REVIEW_PATTERN = new RegExp([
  "\\b(analy[sz]e|review|recap)\\b",
  "\\b(this|last|past|my|whole) (week|month|fortnight)\\b",
  "\\bpast \\d+ days\\b",
  "\\b(am i|are we) (improving|progressing|on track)\\b",
  "\\b(trend|trends|progress so far|compare|compared)\\b",
].join("|"), "i");

const PLAN_EDIT_PATTERN = new RegExp([
  "\\b(new|different|fresh) (plan|program|programme|split|routine)\\b",
  "\\b(regenerate|rebuild|redo|restructure)\\b",
  "\\bchange (my |the )?(plan|program|programme|split|schedule|routine)\\b",
  "\\b(reschedule|postpone|push back|shift|move) (my |today'?s |the )?" +
    "(workout|session|training|plan|leg day|push day|pull day)\\b",
  "\\b(swap|replace|substitute)\\b",
  "\\bskip (today|my workout|the workout|training)\\b",
  "\\b(make|keep) (it|today|the session|my workout) (lighter|easier|harder)\\b",
  "\\b(session|workout|training) (lighter|easier|harder|shorter)\\b",
  "\\b(lighter|easier|harder|shorter) (session|workout|training|day)\\b",
  "\\b(deload|more intense)\\b",
].join("|"), "i");

const LOG_PATTERN = new RegExp([
  "\\b(log|logged|track|record|add|ate|eaten|had|drank|drink)\\b",
  "\\b\\d+(\\.\\d+)?\\s?" +
    "(ml|l|litres?|liters?|kg|lbs?|g|reps?|sets?|hours?|h)\\b",
  "\\b(glass|bottle|cup|bowl|plate|serving|slept|weigh|weighed)\\b",
  "\\b(tick|untick|mark|complete|done with|finished)\\b",
].join("|"), "i");

const REMEMBER_PATTERN = new RegExp([
  "\\b(remember|memori[sz]e)\\b",
  "\\b(don'?t|do not|never) forget\\b",
  "\\bkeep in mind\\b",
  "\\b(make a )?note (that|of)\\b",
].join("|"), "i");

export const asksToRemember = (message: string): boolean =>
  REMEMBER_PATTERN.test(message);

export const classifyWaveIntent = (message: string): WaveIntent => {
  if (PLAN_EDIT_PATTERN.test(message)) return "planEdit";
  if (REVIEW_PATTERN.test(message)) return "review";
  if (LOG_PATTERN.test(message)) return "log";
  return "chat";
};

export const routeOf = (intent: WaveIntent, premium: boolean): WaveRoute =>
  premium && (intent === "review" || intent === "planEdit") ?
    "deep" :
    "light";

export const routeConfigOf = (route: WaveRoute): WaveRouteConfig =>
  WAVE_CHAT_ROUTES[route];
