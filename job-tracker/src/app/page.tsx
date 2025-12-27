"use client";
import Image from "next/image";
import { useEffect, useState } from "react";
import axios from "axios";

export default function Home() {
  const [message, setMessage] = useState("Loading...");

  useEffect(() => {
    getExample().then((data) => setMessage(data));
  }, []);

  return (
    <div className="flex min-h-screen items-center justify-center bg-zinc-50 font-sans dark:bg-black">
      <div>
        <h1 className="text-4xl">Job Tracking Application</h1>
        <p>{message}</p>
      </div>
    </div>
  );
}

async function getExample(){
  const data = await axios.get("http://localhost:3000/api/example");
  return data.data;
}
