export interface PlayerEntity {
  id: number;
  name: string;
}

export type Player = Omit<PlayerEntity, 'id'> & Partial<{ id: number }>;
