import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  ManyToMany,
  JoinTable,
  CreateDateColumn,
  UpdateDateColumn,
  JoinColumn,
} from "typeorm";
import { Owner } from "./owner";
import { Author } from "./author";
import { Genre } from "./genre";

@Entity("books")
export class Book {
  @PrimaryGeneratedColumn()
  id!: number

  @Column()
  title!: string

  @CreateDateColumn()
  created_at!: Date

  @UpdateDateColumn()
  updated_at!: Date

  @ManyToOne(() => Owner, (owner) => owner.books, { eager: true })
  @JoinColumn({ name: "owner_id" })
  owner!: Awaited<Owner>

  @ManyToOne(() => Author, (author) => author.books, { eager: true })
  @JoinColumn({ name: "author_id" })
  author!: Awaited<Author>

  @ManyToMany(() => Genre, (genre) => genre.books, { eager: true })
  @JoinTable({
    name: "books_genres",
    joinColumn: {
      name: "book_id",
      referencedColumnName: "id"
    },
    inverseJoinColumn: {
      name: "genre_id",
      referencedColumnName: "id"
    }
  })
  genres!: Awaited<Genre[]>
}
