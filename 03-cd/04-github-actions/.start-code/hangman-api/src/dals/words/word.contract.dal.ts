import { WordEntity } from '../entities';

export interface WordDAL {
  addWord(word: WordEntity): Promise<WordEntity>;
}

export type WordDALFactory = (...args: any[]) => WordDAL;
