import type { Metadata } from "next";
import "@/globals.css";
import { StrictMode } from "react";
import "reflect-metadata";
import { Inter } from "next/font/google";

import Header from "@/components/organisms/Header";

export const metadata: Metadata = {
  title: "Churchill Library",
  description: "Collection of books belonging to members of the Churchill household"
};

const inter = Inter({
  subsets: ["latin"],
  display: "swap",
});

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <StrictMode>
      <html lang="en" className={inter.className}>
        <body>
          <Header />
          <main className="container max-w-screen-xl mx-auto mb-16 md:mb-8 mt-4 md:mt-8 lg:mt-12 px-5 flex flex-col">
            {children}
          </main>
        </body>
      </html>
    </StrictMode>
  );
}
