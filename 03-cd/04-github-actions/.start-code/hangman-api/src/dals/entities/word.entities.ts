type WordCategory = 'clothes' | 'sports' | 'vehicles';

export interface WordEntity {
  id?: number;
  word_category: WordCategory;
  entry: string;
  created_at?: string;
  updated_at?: string;
}
