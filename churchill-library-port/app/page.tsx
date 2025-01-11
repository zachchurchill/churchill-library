import Heading from "./components/atoms/Header";
import Text from "@/components/atoms/Text";

export default function Home() {
  return (
    <div className="mx-auto max-w-2xl text-center">
      <Heading className="object-center text-4xl sm:text-6xl">Welcome to the Library</Heading>
      <Text className="mt-6 text-lg">The Churchill Library is a hodgepodge, thrown-together rigamarole filled with excitement, tears, and love. Enjoy your stay.</Text>
    </div>
  );
}
