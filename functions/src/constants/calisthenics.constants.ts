export const CALISTHENICS_COURSE_PREFIX = "calisthenics-l";

export interface CalLevelSpec {
  number: number;
  focus: string;
  weeks: number;
  sessions: number;
  minutes: number;
  experience: "Beginner" | "Intermediate" | "Advanced";
}

export const CALISTHENICS_LEVELS: CalLevelSpec[] = [
  {
    number: 1,
    focus: "Base Strength",
    weeks: 8,
    sessions: 3,
    minutes: 50,
    experience: "Beginner",
  },
  {
    number: 2,
    focus: "Strength Foundation",
    weeks: 12,
    sessions: 4,
    minutes: 65,
    experience: "Intermediate",
  },
  {
    number: 3,
    focus: "Strength + Skill",
    weeks: 12,
    sessions: 5,
    minutes: 80,
    experience: "Advanced",
  },
  {
    number: 4,
    focus: "Peak Strength & Elite Skills",
    weeks: 12,
    sessions: 6,
    minutes: 90,
    experience: "Advanced",
  },
];

export const CALISTHENICS_WARM_UP = "jumping-jacks";
export const CALISTHENICS_COOL_DOWN = "downshift-breathing";
export const CALISTHENICS_RESERVE = 2;

export type CalMoveSpec = [string, number, number, number];

export interface CalSessionSpec {
  name: string;
  focus: string;
  goal: string;
  moves: CalMoveSpec[];
}

export const CALISTHENICS_SESSIONS: Record<number, CalSessionSpec[]> = {
  1: [
    {
      name: "Full Body A",
      focus: "Base Strength",
      goal: "Learn the patterns: incline push, row, box squat, bridge.",
      moves: [
        ["high-incline-push-up", 3, 8, 90],
        ["bent-knee-inverted-row", 3, 6, 90],
        ["box-squat", 3, 10, 90],
        ["glute-bridge", 3, 12, 60],
        ["dead-hang", 2, 20, 60],
        ["dead-bug", 3, 6, 60],
      ],
    },
    {
      name: "Full Body B",
      focus: "Base Strength",
      goal: "Slow negatives and single-leg control.",
      moves: [
        ["negative-push-up", 3, 5, 90],
        ["scapular-pull-up", 2, 8, 90],
        ["reverse-lunge", 3, 6, 90],
        ["bodyweight-calf-raise", 2, 15, 45],
        ["plank", 3, 20, 60],
        ["dynamic-bird-dog", 3, 6, 45],
      ],
    },
    {
      name: "Full Body C",
      focus: "Base Strength",
      goal: "One step harder than Monday, plus your first pull-up negatives.",
      moves: [
        ["low-incline-push-up", 3, 8, 90],
        ["inverted-row", 3, 6, 90],
        ["negative-pull-up", 2, 3, 120],
        ["step-up", 3, 8, 90],
        ["tuck-hollow-hold", 3, 10, 60],
        ["superman-raise", 2, 10, 45],
      ],
    },
  ],
  2: [
    {
      name: "Upper A: Strength",
      focus: "Strength",
      goal: "Strict pull-ups, full push-ups and dips.",
      moves: [
        ["pull-up", 4, 3, 150],
        ["push-up", 4, 6, 120],
        ["parallel-bar-dip", 3, 5, 120],
        ["feet-elevated-row", 3, 8, 90],
        ["pike-push-up", 3, 5, 90],
        ["hollow-body-hold", 3, 15, 60],
      ],
    },
    {
      name: "Lower A",
      focus: "Legs",
      goal: "Single-leg strength and slow Nordic lowers.",
      moves: [
        ["bulgarian-split-squat", 3, 8, 90],
        ["assisted-pistol-squat", 3, 4, 120],
        ["nordic-curl-negative", 3, 3, 120],
        ["hanging-knee-raise", 3, 8, 60],
        ["side-plank", 2, 20, 45],
      ],
    },
    {
      name: "Upper B: Volume & Skill",
      focus: "Volume & Skill",
      goal: "Fresh skill holds first, then pulling and pushing volume.",
      moves: [
        ["tuck-l-sit", 4, 10, 75],
        ["tuck-front-lever", 4, 5, 90],
        ["chin-up", 4, 4, 150],
        ["decline-push-up", 4, 8, 90],
        ["archer-push-up", 3, 4, 120],
        ["wide-inverted-row", 3, 8, 90],
        ["band-pull-apart", 3, 12, 45],
      ],
    },
    {
      name: "Lower B",
      focus: "Power & Legs",
      goal: "Explosive jumps first, then controlled single-leg work.",
      moves: [
        ["box-jump", 3, 5, 90],
        ["shrimp-squat", 3, 3, 120],
        ["single-leg-rdl", 3, 8, 90],
        ["single-leg-calf-raise", 3, 12, 45],
        ["hanging-leg-raise", 3, 6, 75],
        ["ab-wheel-rollout", 3, 6, 75],
      ],
    },
  ],
  3: [
    {
      name: "Pull A: Strength",
      focus: "Pull Strength",
      goal: "Front lever raises fresh, then heavy weighted pulls.",
      moves: [
        ["front-lever-raise", 4, 3, 120],
        ["weighted-pull-up", 4, 3, 180],
        ["front-lever-row", 3, 6, 120],
        ["typewriter-pull-up", 3, 4, 120],
        ["ring-biceps-curl", 2, 10, 60],
        ["toes-to-bar", 4, 6, 75],
      ],
    },
    {
      name: "Push A: Strength",
      focus: "Push Strength",
      goal: "Planche leans fresh, then weighted dips and leaning push-ups.",
      moves: [
        ["planche-lean", 3, 15, 90],
        ["weighted-dip", 4, 3, 180],
        ["pseudo-planche-push-up", 3, 6, 120],
        ["archer-push-up", 3, 4, 120],
        ["ring-triceps-extension", 2, 8, 60],
      ],
    },
    {
      name: "Legs & Core",
      focus: "Legs & Core",
      goal: "Jumps fresh, then pistols, shrimps and full Nordics.",
      moves: [
        ["box-jump", 3, 5, 90],
        ["pistol-squat", 4, 4, 150],
        ["shrimp-squat", 3, 5, 120],
        ["nordic-curl", 4, 4, 150],
        ["single-leg-rdl", 3, 8, 90],
        ["single-leg-calf-raise", 3, 12, 45],
        ["dragon-flag-negative", 3, 3, 90],
      ],
    },
    {
      name: "Upper Hypertrophy & Muscle-up",
      focus: "Hypertrophy & Skill",
      goal: "Muscle-ups and L-sits fresh, then upper-body volume.",
      moves: [
        ["muscle-up", 5, 2, 150],
        ["l-sit", 4, 10, 60],
        ["wide-grip-pull-up", 4, 6, 120],
        ["wall-hspu", 4, 3, 150],
        ["ring-dip", 3, 8, 90],
        ["ring-row", 3, 10, 75],
      ],
    },
    {
      name: "Skill Day: Low Fatigue",
      focus: "Skill",
      goal: "Quality, not fatigue: handstand, planche and lever holds.",
      moves: [
        ["wall-handstand", 6, 20, 60],
        ["tuck-planche", 5, 8, 90],
        ["adv-tuck-front-lever", 5, 6, 90],
        ["tuck-back-lever", 3, 8, 90],
        ["hollow-body-rock", 3, 15, 45],
      ],
    },
  ],
  4: [
    {
      name: "Pull Strength & Front Lever",
      focus: "Pull Strength",
      goal: "Front lever work fresh, then heavy weighted pulls.",
      moves: [
        ["front-lever-raise", 5, 3, 150],
        ["adv-tuck-front-lever", 5, 5, 90],
        ["weighted-pull-up", 5, 2, 180],
        ["one-arm-chin-up", 3, 2, 150],
        ["front-lever-row", 3, 6, 120],
        ["dragon-flag", 4, 4, 90],
      ],
    },
    {
      name: "Push Strength & Planche",
      focus: "Push Strength",
      goal: "Planche and ring support fresh, then heavy dips and HSPU.",
      moves: [
        ["adv-tuck-planche", 6, 5, 120],
        ["ring-support-hold", 3, 20, 60],
        ["weighted-dip", 4, 3, 180],
        ["planche-push-up", 3, 3, 150],
        ["freestanding-hspu", 4, 3, 150],
      ],
    },
    {
      name: "Legs & Core",
      focus: "Legs & Core",
      goal: "Single-leg jumps and V-sits fresh, then weighted legs.",
      moves: [
        ["single-leg-box-jump", 4, 3, 120],
        ["l-sit", 5, 10, 60],
        ["weighted-pistol-squat", 4, 3, 150],
        ["nordic-curl", 4, 5, 150],
        ["weighted-bulgarian-split-squat", 3, 6, 120],
        ["single-leg-calf-raise", 3, 10, 45],
        ["toes-to-bar", 4, 6, 75],
      ],
    },
    {
      name: "Skill & Prehab",
      focus: "Skill",
      goal: "Handstand, flag, muscle-up and back lever quality.",
      moves: [
        ["freestanding-handstand", 8, 30, 45],
        ["tuck-human-flag", 5, 4, 90],
        ["muscle-up", 5, 2, 120],
        ["back-lever", 4, 6, 90],
        ["banded-external-rotation", 3, 12, 30],
      ],
    },
    {
      name: "Pull Hypertrophy",
      focus: "Pull Hypertrophy",
      goal: "Weighted chin-ups and pulling volume.",
      moves: [
        ["weighted-chin-up", 4, 6, 120],
        ["archer-pull-up", 3, 5, 120],
        ["ring-row", 3, 8, 90],
        ["ring-biceps-curl", 2, 10, 60],
        ["hanging-l-sit-raise", 3, 8, 75],
      ],
    },
    {
      name: "Push Hypertrophy",
      focus: "Push Hypertrophy",
      goal: "Weighted push-ups, ring dips and pressing volume.",
      moves: [
        ["weighted-push-up", 3, 8, 90],
        ["ring-dip", 3, 6, 120],
        ["deficit-hspu", 3, 6, 120],
        ["one-arm-push-up", 3, 3, 120],
        ["ring-triceps-extension", 2, 10, 60],
      ],
    },
  ],
};
