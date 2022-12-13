export type GameState = 'not_started' | 'started' | 'finished';

export interface GameEntity {
    id?: number;
    player_id: number;
    word_id: number;
    game_state: GameState;
    created_at?: string;
    updated_at?: string;
}
