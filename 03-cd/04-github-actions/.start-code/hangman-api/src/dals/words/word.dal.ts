import { Knex } from 'knex';
import { WordEntity } from '../entities';
import { WordDALFactory } from './word.contract.dal';

export const wordDALFactory: WordDALFactory = (knex: Knex) => ({
  async addWord(word: WordEntity): Promise<WordEntity> {
    const result = await knex<WordEntity>('words').insert([{ ...word }], '*');
    const [w] = result;
    return w;
  },
});
