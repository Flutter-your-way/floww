import {zodTextFormat} from "openai/helpers/zod";
import {ApiError} from "../common/api.error";
import {clamp, roundTo, toAmount, toAmounts} from "../common/utils";
import {
  FOOD_SCAN_MODEL,
  FOOD_SCAN_REASONING_EFFORT,
} from "../constants/ai.constants";
import {
  FoodAnalysis,
  FoodIngredient,
  foodAnalysisSchema,
} from "../models/food.model";
import {
  FOOD_SCAN_INSTRUCTIONS,
  buildFoodScanUserText,
} from "../prompts/food.scan.prompt";
import {ScanFoodRequest} from "../validators/scan.food.validator";
import {getOpenAI} from "./openai.helper";
import {AiTokenUsage} from "./usage.helper";

export interface FoodAnalysisResult {
  analysis: FoodAnalysis;
  usage: AiTokenUsage;
}

const sumOf = (
  ingredients: FoodIngredient[],
  key: "calories" | "proteinG" | "carbsG" | "fatG",
): number => ingredients.reduce((total, item) => total + item[key], 0);

const sanitizeIngredient = (ingredient: FoodIngredient): FoodIngredient => ({
  name: ingredient.name.trim(),
  quantity: ingredient.quantity.trim(),
  weightG: toAmount(ingredient.weightG),
  calories: toAmount(ingredient.calories, 0),
  proteinG: toAmount(ingredient.proteinG),
  carbsG: toAmount(ingredient.carbsG),
  fatG: toAmount(ingredient.fatG),
});

export const sanitizeFoodAnalysis = (analysis: FoodAnalysis): FoodAnalysis => {
  const ingredients = analysis.ingredients.map(sanitizeIngredient);
  const macros = toAmounts(analysis.nutrition.macros);
  const hasIngredients = ingredients.length > 0;

  return {
    isFood: analysis.isFood,
    name: analysis.name.trim(),
    description: analysis.description.trim(),
    servingDescription: analysis.servingDescription.trim(),
    servingWeightG: toAmount(analysis.servingWeightG),
    confidence: roundTo(clamp(analysis.confidence, 0, 1), 2),
    healthScore: Math.round(clamp(analysis.healthScore, 1, 10)),
    ingredients,
    nutrition: {
      macros: {
        ...macros,
        calories: toAmount(
          hasIngredients ? sumOf(ingredients, "calories") : macros.calories,
          0,
        ),
        proteinG: hasIngredients ?
          toAmount(sumOf(ingredients, "proteinG")) : macros.proteinG,
        carbsG: hasIngredients ?
          toAmount(sumOf(ingredients, "carbsG")) : macros.carbsG,
        fatG: hasIngredients ?
          toAmount(sumOf(ingredients, "fatG")) : macros.fatG,
      },
      vitamins: toAmounts(analysis.nutrition.vitamins),
      minerals: toAmounts(analysis.nutrition.minerals),
    },
  };
};

export const analyzeFoodImage = async (
  request: ScanFoodRequest,
): Promise<FoodAnalysisResult> => {
  const response = await getOpenAI().responses.parse({
    model: FOOD_SCAN_MODEL,
    reasoning: {effort: FOOD_SCAN_REASONING_EFFORT},
    instructions: FOOD_SCAN_INSTRUCTIONS,
    input: [
      {
        role: "user",
        content: [
          {type: "input_text", text: buildFoodScanUserText(request.note)},
          {
            type: "input_image",
            image_url: `data:${request.mimeType};base64,${request.image}`,
            detail: "auto",
          },
        ],
      },
    ],
    text: {format: zodTextFormat(foodAnalysisSchema, "food_analysis")},
  });

  if (!response.output_parsed) {
    throw new ApiError("AI_FAILED", "WAVE could not analyze this photo.");
  }

  return {
    analysis: sanitizeFoodAnalysis(response.output_parsed),
    usage: {
      inputTokens: response.usage?.input_tokens ?? 0,
      outputTokens: response.usage?.output_tokens ?? 0,
    },
  };
};
