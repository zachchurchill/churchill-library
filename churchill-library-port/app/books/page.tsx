import { AppDataSource } from "@/db/data-source";
import { Author } from "@/db/entity/author";
import { Owner } from "@/db/entity/owner";
import { Genre } from "@/db/entity/genre";
import { Book } from "@/db/entity/book";

export default async () => {
  const authors = await AppDataSource.manager.find(Author);
  const owners = await AppDataSource.manager.find(Owner);
  const genres = await AppDataSource.manager.find(Genre);
  const books = await AppDataSource.manager.find(Book);
  return (
    <>
    <section id="top-matter">
      <h1 className="font-semibold text-2xl leading-tight tracking-tight text-slate-800">Browse our books</h1>
      <p className="leading-8 text-slate-600">The Churchill Library houses books from all our family members. Explore our books using the provided search and filters.</p>
    </section>
    <section id="search-and-filters" className="mt-4 flex flex-col md:flex-row justify-between gap-4">
      <form className="basis-3/4 flex flex-col justify-between gap-2">
        <div className="relative">
          <svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg" className="inline absolute mt-4 ml-3">
            <path
              d="M13 13L10.1 10.1M11.6667 6.33333C11.6667 9.27885 9.27885 11.6667 6.33333 11.6667C3.38781 11.6667 1 9.27885 1 6.33333C1 3.38781 3.38781 1 6.33333 1C9.27885 1 11.6667 3.38781 11.6667 6.33333Z"
              stroke="#1E1E1E"
              strokeWidth="1.6"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
          <input
            id="title-search"
            type="text"
            placeholder="Search by title..."
            className="w-full pl-8 rounded-full border border-solid border-slate-200 focus:border-transparent focus:shadow-none"
          />
        </div>
        <div className="flex md:flex-row flex-col">
          <SelectDropdown label="Owner" options={owners} className="w-full mr-0 md:mr-3" />
          <SelectDropdown label="Author" options={authors} className="w-full mx-0 md:mx-2" />
          <SelectDropdown label="Genre" options={genres} className="w-full ml-0 md:ml-3" />
        </div>
      </form>
      <div className="basis-1/4 min-h-12 md:max-w-64 flex flex-row md:flex-col justify-end gap-2">
        <button id="ai-chat" className="basis-full md:basis-12 py-2 md:py-0 rounded-md text-xs md:text-sm font-semibold text-white shadow-sm bg-green-800 hover:bg-green-700 cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-green-800" disabled>Chat with Librarian</button>
      </div>
    </section>
    <BooksTable books={books} />
    </>
  );
};

type SelectDropdownProps = {
  label: string,
  options: (Author | Owner | Genre)[],
  className?: string
};

const SelectDropdown: React.FC<SelectDropdownProps> = ({ options, label, className }) => {
  const selectId = `${label}-filter`;
  return (
    <div className={className}>
      <label htmlFor={selectId} className="block text-xs md:text-sm font-medium leading-6 text-gray-900">{label}</label>
      <select
        id={selectId}
        className="w-full rounded-lg border border-solid border-slate-200"
      >
        <option value="">All {label}s</option>
        {options.map((option, idx) => <option key={idx} value={option.id}>{option.name}</option>)}
      </select>
    </div>
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
