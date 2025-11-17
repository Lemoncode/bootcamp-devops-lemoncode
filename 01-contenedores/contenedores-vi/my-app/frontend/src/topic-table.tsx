import React from "react";
import { createSwapy } from "swapy";
import { Topic } from "./model";
import { TopicRow } from "./topic-row";

export const TopicTable = () => {
  const [topics, setTopics] = React.useState<Topic[]>([]);
  const [loading, setLoading] = React.useState(true);
  const [newTopicName, setNewTopicName] = React.useState("");
  const [showForm, setShowForm] = React.useState(false);
  const [error, setError] = React.useState("");
  const containerRef = React.useRef<HTMLDivElement>(null);

  // Fetch topics
  React.useEffect(() => {
    fetchTopics();
  }, []);

  const fetchTopics = () => {
    fetch("http://localhost:8080/api/topics")
      .then((response) => response.json())
      .then((result) => {
        setTopics(result);
        setLoading(false);
        setError("");
      })
      .catch((error) => {
        console.error("Error loading topics:", error);
        setError("Failed to load topics");
        setLoading(false);
      });
  };

  // Initialize Swapy
  React.useEffect(() => {
    if (containerRef.current && topics.length > 0) {
      const swapy = createSwapy(containerRef.current);

      swapy.onSwap((event) => {
        console.log("Swap event:", event);
      });

      return () => {
        swapy.destroy();
      };
    }
  }, [topics]);

  // Create new topic
  const handleCreateTopic = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (!newTopicName.trim()) {
      setError("Topic name cannot be empty");
      return;
    }

    try {
      const response = await fetch("http://localhost:8080/api/topics", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ name: newTopicName }),
      });

      if (!response.ok) {
        throw new Error("Failed to create topic");
      }

      setNewTopicName("");
      setShowForm(false);
      await fetchTopics();
    } catch (error) {
      console.error("Error creating topic:", error);
      setError("Failed to create topic. Please try again.");
    }
  };

  // Delete topic
  const handleDeleteTopic = async (id: string) => {
    if (!window.confirm("Are you sure you want to delete this topic?")) {
      return;
    }

    try {
      const response = await fetch(`http://localhost:8080/api/topics/${id}`, {
        method: "DELETE",
      });

      if (!response.ok) {
        throw new Error("Failed to delete topic");
      }

      await fetchTopics();
    } catch (error) {
      console.error("Error deleting topic:", error);
      setError("Failed to delete topic. Please try again.");
    }
  };

  if (loading) {
    return (
      <div className="loading-container">
        <div className="spinner"></div>
      </div>
    );
  }

  return (
    <div className="app-container">
      {/* Header Section */}
      <div className="header-section">
        <h1 className="header-title">📚 Topics Manager</h1>
        <p className="header-subtitle">
          ✨ Manage, create, and organize your topics with drag and drop
        </p>
        <div className="metrics-container">
          <div className="metric-card">
            <div className="metric-label">Total Topics</div>
            <div className="metric-value">{topics.length}</div>
          </div>
          <div className="metric-card">
            <div className="metric-label">Dashboard Status</div>
            <div className="metric-value">✓ Active</div>
          </div>
          <div className="metric-card">
            <div className="metric-label">Last Updated</div>
            <div className="metric-value">{new Date().toLocaleTimeString()}</div>
          </div>
        </div>
      </div>

      {/* Error Message */}
      {error && (
        <div className="error-banner">
          <span className="error-icon">⚠️</span>
          <span className="error-message">{error}</span>
          <button
            className="error-close"
            onClick={() => setError("")}
          >
            ✕
          </button>
        </div>
      )}

      {/* Create Topic Section */}
      <div className="create-topic-section">
        {!showForm ? (
          <button
            className="create-topic-btn"
            onClick={() => setShowForm(true)}
          >
            ➕ Create New Topic
          </button>
        ) : (
          <form className="create-topic-form" onSubmit={handleCreateTopic}>
            <div className="form-group">
              <input
                type="text"
                placeholder="Enter topic name..."
                value={newTopicName}
                onChange={(e) => setNewTopicName(e.target.value)}
                className="form-input"
                autoFocus
              />
            </div>
            <div className="form-actions">
              <button type="submit" className="form-submit-btn">
                ✓ Create
              </button>
              <button
                type="button"
                className="form-cancel-btn"
                onClick={() => {
                  setShowForm(false);
                  setNewTopicName("");
                  setError("");
                }}
              >
                ✕ Cancel
              </button>
            </div>
          </form>
        )}
      </div>

      {/* Topics Grid */}
      <div className="dashboard-section">
        <h2 className="dashboard-title">🎯 Your Topics</h2>
        {topics.length === 0 ? (
          <div className="empty-state">
            <div className="empty-state-icon">📭</div>
            <div className="empty-state-text">
              No topics yet. Create your first topic to get started!
            </div>
          </div>
        ) : (
          <>
            <p className="dashboard-subtitle">
              🖱️ Drag and drop cards to reorder them interactively
            </p>
            <div className="swapy-container" ref={containerRef}>
              {topics.map((topic) => (
                <div key={topic.id} data-swapy-slot={topic.id}>
                  <div data-swapy-item={topic.id}>
                    <TopicRow topic={topic} onDelete={handleDeleteTopic} />
                  </div>
                </div>
              ))}
            </div>
          </>
        )}
      </div>
    </div>
  );
};
