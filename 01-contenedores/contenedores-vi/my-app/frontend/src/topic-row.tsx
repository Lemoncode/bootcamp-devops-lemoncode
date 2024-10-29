import React from "react";
import { Topic } from "./model";

interface Props {
  topic: Topic;
}

export const TopicRow: React.FC<Props> = (props) => {
  const { topic } = props;

  return (
    <tr key={topic.id}>
      <td>{topic.id}</td>
      <td>{topic.name}</td>
    </tr>
  );
};
