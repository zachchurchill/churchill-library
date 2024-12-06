import { AppDataSource } from "@/db/data-source";
import { Author } from "@/db/entity/author";
import { Genre } from "@/db/entity/genre";
import { Owner } from "@/db/entity/owner";
import { Book } from "@/db/entity/book";

export default async () => {
  const owners = await AppDataSource.manager.find(Owner);
  const authors = await AppDataSource.manager.find(Author);
  const genres = await AppDataSource.manager.find(Genre);
  const books = await AppDataSource.manager.find(Book);
  return (
    <section>
      <h1 className="text-xl">Data!</h1>
      <ul className="list-disc list-inside">
        <li>{owners.map(owner => owner.name).join(", ")}</li>
        <li>{authors.map(author => author.name).join(", ")}</li>
        <li>{genres.map(genre => genre.name).join(", ")}</li>
      </ul>
      <table className="table-auto">
        <thead>
          <tr>
            <th>Title</th>
          </tr>
        </thead>
        <tbody>
          {
            books.map((book, idx) => {
              return (
                <tr key={idx}>
                  <td>{book.title}</td>
                </tr>
              );
            })
          }
        </tbody>
      </table>
    </section>
  );
};
