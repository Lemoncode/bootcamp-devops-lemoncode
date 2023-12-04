import Chance from 'chance';

const chance = new Chance();

export interface WordCategory {
  categoryId: number;
  categoryLength: number;
}

export interface WordProviderSetup {
  categoriesCount: number;
  wordCategoryCollection: WordCategory[];
}

const wordProviderSetup: WordProviderSetup = {
  categoriesCount: 0,
  wordCategoryCollection: [],
};

export const setUp = (categoriesCount: number, wordCategories: WordCategory[]) => {
  wordProviderSetup.categoriesCount = categoriesCount;
  wordProviderSetup.wordCategoryCollection = [...wordCategories];
};

export interface SelectedWord {
  categoryIndex: number;
  wordIndex: number;
}

// TODO: Throw custom exception for service not initialized.
export const selectWord = (): SelectedWord => {
  const categoryIndex = chance.integer({ min: 0, max: wordProviderSetup.categoriesCount - 1 });
  const wordCategory = wordProviderSetup.wordCategoryCollection.find((w) => w.categoryId === categoryIndex);
  const wordIndex = chance.integer({ min: 0, max: wordCategory!.categoryLength - 1 });
  return {
    categoryIndex,
    wordIndex,
  };
};
