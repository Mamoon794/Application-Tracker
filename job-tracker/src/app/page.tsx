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
  const inProgress = jobs.filter(job => job.status !== "Rejected").length;
  const offers = jobs.filter(job => job.status === "Offer").length;
  const [searchText, setSearchText] = useState("");
  const filteredJobs = jobs.filter((job) => {
  const text = searchText.toLowerCase().trim();
  if (!text) return true; return (  //if search is empty return all
    job.company.toLowerCase().includes(text) ||
    job.position.toLowerCase().includes(text)
  );
});



  return (
    <div className="min-h-screen bg-zinc-50 font-sans text-zinc-900 dark:bg-zinc-950 dark:text-zinc-100 p-4 md:p-8">
      <div className="max-w-6xl mx-auto bg-white">
        {/* Header */}
        <header>
          <h1 className="text-4xl font-bold mb-4">Job Tracker</h1>
        </header>

        {/* Status Card */}
       <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <JobStatusCard title="Total Applied" value={totalApplied} icon={<Briefcase />} color="blue"/>
          <JobStatusCard title="In Progress" value={inProgress} icon={<Briefcase />} color="yellow"/>
          <JobStatusCard title="Offers" value={offers} icon={<Briefcase />} color="green"/>
        </div>

        {/* Search Bar */}
        <div className="mb-4 flex items-center gap-3">
          <input type="text" placeholder="Search by company or position..." value={searchText} onChange={(e) => setSearchText(e.target.value)} className="w-full max-w-md rounded-full border border-zinc-300 px-4 py-2 text-sm"/>
          <select className="rounded-full border border-zinc-300 px-3 py-2 text-sm bg-white">
            <option value="">All Statuses</option>
            <option value="Applied">Applied</option>
            <option value="Interviewing">Interviewing</option>
            <option value="Offer">Offer</option>
            <option value="Rejected">Rejected</option>
          </select>
        </div>

        {/* Job Tracking Table */}
        <div className="space-y-2">
            {filteredJobs.map((job) => (
              <div
                key={job.id}
                className="flex items-center justify-between rounded-lg border border-zinc-200 bg-white px-4 py-3"
              >
                <div>
                  <p className="font-medium">{job.company}</p>
                  <p className="text-xs text-zinc-500">{job.position}</p>
                </div>

                <div className="flex items-center gap-4">
                  <span className="text-xs text-zinc-500">{job.date}</span>
                  <span className="text-xs rounded-full bg-zinc-100 px-3 py-1">
                    {job.status}
                  </span>
                </div>
              </div>
            ))}
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
