export interface TodoEntity {
    id: number;
    title: string;
    completed: boolean;
    due_date?: string;
    order?: number;
}