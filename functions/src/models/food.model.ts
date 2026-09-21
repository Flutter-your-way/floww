import {z} from "zod";

export const macroNutrientsSchema = z.object({
  calories: z.number(),
  proteinG: z.number(),
  carbsG: z.number(),
  fatG: z.number(),
  fiberG: z.number(),
  sugarG: z.number(),
  addedSugarG: z.number(),
  saturatedFatG: z.number(),
  transFatG: z.number(),
  monounsaturatedFatG: z.number(),
  polyunsaturatedFatG: z.number(),
  cholesterolMg: z.number(),
  waterMl: z.number(),
});

export const vitaminsSchema = z.object({
  vitaminAMcg: z.number(),
  vitaminB1Mg: z.number(),
  vitaminB2Mg: z.number(),
  vitaminB3Mg: z.number(),
  vitaminB5Mg: z.number(),
  vitaminB6Mg: z.number(),
  vitaminB7Mcg: z.number(),
  vitaminB9Mcg: z.number(),
  vitaminB12Mcg: z.number(),
  vitaminCMg: z.number(),
  vitaminDMcg: z.number(),
  vitaminEMg: z.number(),
  vitaminKMcg: z.number(),
  cholineMg: z.number(),
});

export const mineralsSchema = z.object({
  calciumMg: z.number(),
  ironMg: z.number(),
  magnesiumMg: z.number(),
  phosphorusMg: z.number(),
  potassiumMg: z.number(),
  sodiumMg: z.number(),
  zincMg: z.number(),
  copperMg: z.number(),
  manganeseMg: z.number(),
  seleniumMcg: z.number(),
  iodineMcg: z.number(),
});

export const foodNutritionSchema = z.object({
  macros: macroNutrientsSchema,
  vitamins: vitaminsSchema,
  minerals: mineralsSchema,
});

export const foodIngredientSchema = z.object({
  name: z.string(),
  quantity: z.string(),
  weightG: z.number(),
  calories: z.number(),
  proteinG: z.number(),
  carbsG: z.number(),
  fatG: z.number(),
});

export const foodAnalysisSchema = z.object({
  isFood: z.boolean(),
  name: z.string(),
  description: z.string(),
  servingDescription: z.string(),
  servingWeightG: z.number(),
  confidence: z.number(),
  healthScore: z.number(),
  ingredients: z.array(foodIngredientSchema),
  nutrition: foodNutritionSchema,
});

export const foodSourceSchema = z.enum(["scan", "manual"]);

export const foodModelSchema = foodAnalysisSchema.omit({isFood: true}).extend({
  id: z.string(),
  userId: z.string(),
  source: foodSourceSchema,
  aiModel: z.string().nullable(),
  promptVersion: z.string().nullable(),
  createdAt: z.iso.datetime(),
});

export type MacroNutrients = z.infer<typeof macroNutrientsSchema>;
export type Vitamins = z.infer<typeof vitaminsSchema>;
export type Minerals = z.infer<typeof mineralsSchema>;
export type FoodNutrition = z.infer<typeof foodNutritionSchema>;
export type FoodIngredient = z.infer<typeof foodIngredientSchema>;
export type FoodAnalysis = z.infer<typeof foodAnalysisSchema>;
export type FoodSource = z.infer<typeof foodSourceSchema>;
export type FoodModel = z.infer<typeof foodModelSchema>;
