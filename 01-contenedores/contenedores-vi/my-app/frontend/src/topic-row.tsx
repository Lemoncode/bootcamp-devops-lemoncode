import React from "react";
import { Topic } from "./model";

interface Props {
  topic: Topic;
  onDelete: (id: string) => void;
}

export const TopicRow: React.FC<Props> = (props) => {
  const { topic, onDelete } = props;

  return (
    <div className="topic-card">
      <div className="topic-card-content">
        <div className="topic-id">{topic.id}</div>
        <h3 className="topic-name">{topic.name}</h3>
        <button
          className="topic-delete-btn"
          onClick={() => onDelete(topic.id)}
          title="Delete this topic"
        >
          Delete
        </button>
      </div>
    </div>
  );
};
