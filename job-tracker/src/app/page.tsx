"use client";
import { useEffect, useState } from "react";
import {Briefcase} from "lucide-react";

export default function Home() {
  // Sample job data
  const jobs = [
    { id: 1, company: 'Google', position: 'Frontend Engineer', status: 'Interviewing', date: '2025-11-24' },
    { id: 2, company: 'Netflix', position: 'Product Designer', status: 'Applied', date: '2025-10-22' },
    { id: 3, company: 'Celestica', position: 'Cybersecurity', status: 'Offer', date: '2025-12-15' },
    { id: 4, company: 'RBC', position: 'Senior React Dev', status: 'Rejected', date: '2025-10-25' },
  ]

  const totalApplied = jobs.length;

  return (
    <div className="min-h-screen bg-zinc-50 font-sans text-zinc-900 dark:bg-zinc-950 dark:text-zinc-100 p-4 md:p-8">
      <div className="max-w-6xl mx-auto bg-white">
        {/* Header */}
        <header>
          <h1 className="text-4xl font-bold mb-4">Job Tracker</h1>
        </header>

        {/* Status Card */}
        <div>
          <JobStatusCard title="Total Applied" value={totalApplied} icon={<Briefcase />} color="blue"/>
        </div>

        {/* Search Bar */}
        <div>

        </div>

        {/* Job Tracking Table */}
        <div>
          
        </div>
      </div>
    </div>
  );
}



/*
  A reusable component to create a status card for job tracking.
  It takes in a title which is the title of the card
  It takes in a value which is the count or statistic to display
  It takes in an icon to display on the very left of the card
  It takes in a color to change the color of the icon background. It can be blue, yellow, or green.
*/
function JobStatusCard({title, value, icon, color}: {title: string, value: string | number, icon: React.ReactNode, color: "blue" | "yellow" | "green"}) {
  const colors = {
    "blue": 'text-blue-600 bg-blue-100',
    "yellow": 'text-yellow-600 bg-yellow-100',
    "green": 'text-green-600 bg-green-100',
  };

  return (
    // This adds white background, padding of 6 pixels, rounded corners, border, border color, shadow small, flexbox layout, center alignment, and gap between items of 4 pixels
    // By default, div puts every tag inside it on a new line, by using flex, it puts them in a row.
    <div className="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm flex items-center gap-4">  
      <div className={`p-3 rounded-lg ${colors[color]}`}>
        {icon}
      </div>
      <div>
        <p className="text-sm text-zinc-500 font-medium">{title}</p>
        <p className="text-2xl font-bold">{value}</p>
      </div>
    </div>
  )
}
