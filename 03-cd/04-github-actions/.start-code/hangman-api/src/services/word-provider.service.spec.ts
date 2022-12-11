import { setUp, selectWord, WordCategory } from './word-provider.service';

describe('word-provider.srv', () => {
  test('returns a valid selectedWord', () => {
    // Arrange
    const categories = [
      {
        category: 'clothes',
        words: ['pants', 't-shirt'],
      },
      {
        category: 'sports',
        words: ['football', 'f1'],
      },
    ];

    const categoryLength = categories.length;
    const wordCategories: WordCategory[] = categories.map((c, index) => ({
      categoryId: index,
      categoryLength: c.words.length,
    }));

    setUp(categoryLength, wordCategories);

    // Act
    const selectedWord = selectWord();
    expect(selectedWord.categoryIndex).toBeLessThanOrEqual(categoryLength - 1);
    expect(selectedWord.wordIndex).toBeLessThanOrEqual(categories[selectedWord.categoryIndex].words.length - 1);
  });
});
