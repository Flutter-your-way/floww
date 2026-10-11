import {readFileSync, writeFileSync} from "fs";
import {join} from "path";
import {
  WAVE_CHAT_PROMPT_VERSION,
  WAVE_EVAL_PASS_RATE,
} from "../constants/ai.constants";
import {
  FREE_ACCESS,
  PREMIUM_ACCESS,
  intentFeatureOf,
} from "../helpers/wave.access.helper";
import {answerWaveChat} from "../helpers/wave.chat.helper";
import {WaveFacts, mergeWaveToday} from "../helpers/wave.facts.helper";
import {groundWaveActions} from "../helpers/wave.ground.helper";
import {
  asksToRemember,
  classifyWaveIntent,
  routeConfigOf,
  routeOf,
} from "../helpers/wave.route.helper";
import {WaveProfile} from "../helpers/wave.digest.helper";
import {
  WaveAction,
  WaveCard,
  WavePremiumFeature,
  WaveRoute,
} from "../models/wave.model";
import {
  WaveHistoryTurn,
  waveTodayValidator,
} from "../validators/wave.chat.validator";

const CASES_FILE = "wave.chat.cases.json";
const CONCURRENCY = 4;
const LIGHT_FLAG = "--light";

interface EvalExpectation {
  route?: WaveRoute;
  actions?: WaveAction[];
  forbid?: WaveAction[];
  rejected?: WaveAction[];
  noActions?: boolean;
  card?: WaveCard;
  locked?: WavePremiumFeature[];
}

interface EvalCase {
  id: string;
  message: string;
  premium?: boolean;
  turns?: WaveHistoryTurn[];
  facts?: Partial<WaveFacts>;
  today?: Record<string, unknown>;
  expect: EvalExpectation;
}

interface EvalSuite {
  profile: WaveProfile;
  history: string;
  facts: WaveFacts;
  today: Record<string, unknown>;
  cases: EvalCase[];
}

interface EvalResult {
  id: string;
  passed: boolean;
  failures: string[];
  route: WaveRoute;
  card: WaveCard;
  actions: WaveAction[];
  rejected: WaveAction[];
  reply: string;
}

const sourceDir = (): string =>
  __dirname.replace(`${join("lib", "src")}`, "src");

const loadSuite = (): EvalSuite =>
  JSON.parse(readFileSync(join(sourceDir(), CASES_FILE), "utf8"));

const missing = <T>(expected: T[] | undefined, actual: T[]): T[] =>
  (expected ?? []).filter((item) => !actual.includes(item));

const failuresOf = (
  expect: EvalExpectation,
  result: Omit<EvalResult, "passed" | "failures"> & {
    locked: WavePremiumFeature[];
  },
): string[] => {
  const failures: string[] = [];
  if (expect.route && expect.route !== result.route) {
    failures.push(`route ${result.route}, expected ${expect.route}`);
  }
  if (expect.card && expect.card !== result.card) {
    failures.push(`card ${result.card}, expected ${expect.card}`);
  }
  const absent = missing(expect.actions, result.actions);
  if (absent.length > 0) failures.push(`missing actions ${absent.join(", ")}`);
  const forbidden = (expect.forbid ?? [])
    .filter((action) => result.actions.includes(action));
  if (forbidden.length > 0) {
    failures.push(`forbidden actions ${forbidden.join(", ")}`);
  }
  if (expect.noActions && result.actions.length > 0) {
    failures.push(`expected no actions, got ${result.actions.join(", ")}`);
  }
  const notRejected = missing(expect.rejected, result.rejected);
  if (notRejected.length > 0) {
    failures.push(`not rejected ${notRejected.join(", ")}`);
  }
  const unlocked = missing(expect.locked, result.locked);
  if (unlocked.length > 0) failures.push(`not locked ${unlocked.join(", ")}`);
  return failures;
};

const runCase = async (
  suite: EvalSuite,
  item: EvalCase,
  light: boolean,
): Promise<EvalResult> => {
  const access = item.premium ? PREMIUM_ACCESS : FREE_ACCESS;
  const facts: WaveFacts = {...suite.facts, ...item.facts};
  const today = mergeWaveToday(
    waveTodayValidator.parse({...suite.today, ...item.today}),
    facts,
  );
  const intent = classifyWaveIntent(item.message);
  const route = routeOf(intent, access.premium);

  try {
    const {answer} = await answerWaveChat({
      uid: `eval-${item.id}`,
      message: item.message,
      turns: item.turns ?? [],
      today,
      profile: suite.profile,
      history: suite.history,
      memory: {
        enabled: access.premium,
        premium: access.premium,
        notes: [],
        summary: "",
      },
      access,
      route: routeConfigOf(light ? "light" : route),
    });
    const grounding = groundWaveActions(answer.actions, facts, access);
    const feature = intentFeatureOf(intent);
    const locked = access.premium ? [] : [
      ...grounding.locked,
      ...(feature ? [feature] : []),
      ...(asksToRemember(item.message) || answer.memory.remember.length > 0 ?
        ["memory" as const] :
        []),
    ];
    const outcome = {
      id: item.id,
      route,
      card: answer.card,
      actions: grounding.actions.map((action) => action.action),
      rejected: grounding.rejected.map((action) => action.action),
      reply: answer.reply,
      locked,
    };
    const failures = failuresOf(item.expect, outcome);
    return {...outcome, passed: failures.length === 0, failures};
  } catch (error) {
    return {
      id: item.id,
      passed: false,
      failures: [`request failed: ${(error as Error).message}`],
      route,
      card: "none",
      actions: [],
      rejected: [],
      reply: "",
    };
  }
};

const runAll = async (
  suite: EvalSuite,
  filter: string | undefined,
  light: boolean,
) => {
  const ids = filter?.split(",") ?? [];
  const cases = suite.cases.filter((item) =>
    ids.length === 0 || ids.some((id) => item.id.includes(id)));
  const results: EvalResult[] = [];
  let cursor = 0;
  const worker = async () => {
    while (cursor < cases.length) {
      const item = cases[cursor++];
      const result = await runCase(suite, item, light);
      results.push(result);
      const mark = result.passed ? "PASS" : "FAIL";
      console.log(`${mark} ${item.id}` +
        (result.passed ? "" : ` — ${result.failures.join("; ")}`));
    }
  };
  await Promise.all(Array.from({length: CONCURRENCY}, worker));
  return results;
};

const main = async () => {
  const suite = loadSuite();
  const args = process.argv.slice(2);
  const light = args.includes(LIGHT_FLAG);
  const filter = args.find((arg) => arg !== LIGHT_FLAG);
  const results = await runAll(suite, filter, light);
  const passed = results.filter((result) => result.passed).length;
  const rate = results.length === 0 ? 0 : passed / results.length;

  writeFileSync(
    join(sourceDir(), "results", `${WAVE_CHAT_PROMPT_VERSION}.json`),
    JSON.stringify({
      promptVersion: WAVE_CHAT_PROMPT_VERSION,
      ranAt: new Date().toISOString(),
      passed,
      total: results.length,
      passRate: rate,
      results: results.sort((a, b) => a.id.localeCompare(b.id)),
    }, null, 2) + "\n",
  );

  console.log(`\n${WAVE_CHAT_PROMPT_VERSION}: ${passed}/${results.length} ` +
    `passed (${Math.round(rate * 100)}%), ` +
    `required ${Math.round(WAVE_EVAL_PASS_RATE * 100)}%`);
  process.exitCode = rate >= WAVE_EVAL_PASS_RATE ? 0 : 1;
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
