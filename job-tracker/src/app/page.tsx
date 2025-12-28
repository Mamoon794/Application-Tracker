export default function Home() {
  return (
    <main style={{ padding: "40px", maxWidth: "800px", margin: "0 auto" }}>
      <h1>Job Tracker</h1>
      <p>Keep track of your job applications.</p>

      <button
        style={{
          marginTop: "10px",
          padding: "10px 14px",
          borderRadius: "6px",
          border: "none",
          background: "black",
          color: "white",
          cursor: "pointer"
        }}
      >
        Add Application
      </button>

      <hr style={{ margin: "20px 0" }} />

      <h2>Applications</h2>

      <ul>
        <li>Google — Frontend Engineer — Interviewing</li>
        <li>Meta — Product Designer — Applied</li>
        <li>Amazon — SDE II — Rejected</li>
      </ul>
    </main>
  );
}
