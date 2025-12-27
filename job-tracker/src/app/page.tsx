import Image from "next/image";
import axios from "axios";

export default function Home() {
  const data = getGoogle();  // Just an example on using axios
  return (
    <div className="flex min-h-screen items-center justify-center bg-zinc-50 font-sans dark:bg-black">
      <h1>Job Tracking Application</h1>
    </div>
  );
}

function getGoogle(){
  axios.get("https://www.google.com").then((res) => {
    return res.data;
  });
}
