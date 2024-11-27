import type { Metadata } from "next";
import "@/globals.css";
import { StrictMode } from "react";

export const metadata: Metadata = {
  title: "Churchill Library",
  description: "Collection of books belonging to members of the Churchill household"
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <StrictMode>
      <html lang="en">
        <body>
          {children}
        </body>
      </html>
    </StrictMode>
  );
}
