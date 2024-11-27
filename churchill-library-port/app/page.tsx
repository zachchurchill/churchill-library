import Header from "@/components/Header";

export default function Home() {
  return (
    <>
    <Header />
    <main className="container max-w-screen-xl mx-auto mb-16 md:mb-8 mt-4 md:mt-8 lg:mt-12 px-5 flex flex-col">
      <div className="mx-auto">
        <div className="relative isolate px-6 lg:px-8">
          <div className="mx-auto max-w-2xl">
            <div className="text-center">
              <h2 className="object-center text-4xl font-bold tracking-tight text-grey sm:text-6xl">Welcome to the Library</h2>
              <p className="mt-6 text-lg leading-8 text-gray-500">The Churchill Library is a hodgepodge, thrown-together rigamarole filled with excitement, tears, and love. Enjoy your stay.</p>
            </div>
          </div>
        </div>
      </div>
    </main>
    </>
  );
}
