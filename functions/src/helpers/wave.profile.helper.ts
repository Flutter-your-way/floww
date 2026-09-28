import {
  WAVE_PROFILE_CACHE_LIMIT,
  WAVE_PROFILE_CACHE_TTL_MS,
} from "../constants/ai.constants";
import {
  onboardingDetailsCollection,
  usersCollection,
} from "../constants/collections";
import {targetsDoc} from "./nutrition.goal.helper";
import {statsDoc} from "./stats.helper";
import {WaveProfile, buildWaveProfile} from "./wave.digest.helper";

interface CacheEntry {
  profile: WaveProfile;
  expiresAt: number;
}

const cache = new Map<string, CacheEntry>();

const readProfile = async (uid: string): Promise<WaveProfile> => {
  const [user, details, stats, targets] = await Promise.all([
    usersCollection.doc(uid).get(),
    onboardingDetailsCollection.doc(uid).get(),
    statsDoc(uid).get(),
    targetsDoc(uid).get(),
  ]);

  return buildWaveProfile(user.data() ?? {}, details.data() ?? {}, {
    stats: stats.data() ?? {},
    targets: targets.data() ?? {},
  });
};

export const loadWaveProfile = async (uid: string): Promise<WaveProfile> => {
  const now = Date.now();
  const cached = cache.get(uid);
  if (cached && cached.expiresAt > now) {
    return cached.profile;
  }

  const profile = await readProfile(uid);

  if (cache.size >= WAVE_PROFILE_CACHE_LIMIT) {
    cache.clear();
  }
  cache.set(uid, {profile, expiresAt: now + WAVE_PROFILE_CACHE_TTL_MS});

  return profile;
};

export const clearWaveProfileCache = (uid?: string): void => {
  if (uid) {
    cache.delete(uid);
    return;
  }
  cache.clear();
};
