import Heading from "@/components/atoms/Header";
import Text from "@/components/atoms/Text";
import SearchField from "@/components/molecules/SearchField";
import { SelectOption } from "@/components/atoms/SelectInput";
import SelectDropdown from "@/components/molecules/SelectDropdown";
import Button from "@/components/atoms/Button";
import { AppDataSource } from "@/db/data-source";
import { Author } from "@/db/entity/author";
import { Owner } from "@/db/entity/owner";
import { Genre } from "@/db/entity/genre";
import { Book } from "@/db/entity/book";

export default async () => {
  const owners: SelectOption[] = (await AppDataSource.manager.find(Owner))
    .map((owner) => ({ id: owner.id.toString(), name: owner.name }));
  const authors: SelectOption[] = (await AppDataSource.manager.find(Author))
    .map((author) => ({ id: author.id.toString(), name: author.name }));
  const genres: SelectOption[] = (await AppDataSource.manager.find(Genre))
    .map((genre) => ({ id: genre.id.toString(), name: genre.name }));
  const books = await AppDataSource.manager.find(Book);

  return (
    <>
    <section id="top-matter">
      <Heading>Browse our books</Heading>
      <Text>The Churchill Library houses books from all our family members. Explore our books using the provided search and filters.</Text>
    </section>
    <section id="search-and-filters" className="mt-4 flex flex-col md:flex-row justify-between gap-4">
      <form className="basis-3/4 flex flex-col justify-between gap-2">
        <SearchField inputId="title-search" placeholder="Search by title..." />
        <div className="flex md:flex-row flex-col">
          <SelectDropdown
            label="Owner"
            options={owners}
            defaultOption={{ id: "", name: "All Owners" }}
            className="mr-0 md:mr-3"
          />
          <SelectDropdown
            label="Author"
            options={authors}
            defaultOption={{ id: "", name: "All Authors" }}
            className="mx-0 md:mx-2"
          />
          <SelectDropdown
            label="Genre"
            options={genres}
            defaultOption={{ id: "", name: "All Genres" }}
            className="ml-0 md:ml-3"
          />
        </div>
      </form>
      <div className="basis-1/4 min-h-12 md:max-w-64 flex flex-row md:flex-col justify-end gap-2">
        <Button label="Chat with Librarian" disabled={true} className="basis-full md:basis-12 py-2 md:py-0" />
      </div>
    </section>
    <BooksTable books={books} />
    </>
  );
};

const BooksTable: React.FC<{ books: Book[] }> = ({ books }) => {
  return (
    <section id="books-table" className="mt-4">
      <table className="w-full table-auto md:table-fixed">
        <thead>
          <tr className="border-b border-solid border-slate-200 text-base md:text-lg text-left text-slate-800">
            <th className="w-2/12 font-medium text-inherit">Owner</th>
            <th className="w-4/12 font-medium text-inherit">Title</th>
            <th className="w-3/12 font-medium text-inherit">Author</th>
            <th className="w-3/12 font-medium text-inherit">Genres</th>
          </tr>
        </thead>
        <tbody className="font-light text-sm md:text-base text-slate-800 space-y-8 md:space-y-6 lg:space-y-4">
        {
          books.map((book, idx) => {
            return (
              <tr key={idx}>
                <td>{book.owner.name}</td>
                <td>{book.title}</td>
                <td>{book.author.name}</td>
                <td>{book.genres.map(genre => genre.name).join(", ")}</td>
              </tr>
            );
          })
        }
        </tbody>
      </table>
    </section>
  );
};
