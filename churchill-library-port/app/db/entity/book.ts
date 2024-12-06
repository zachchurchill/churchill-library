import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  ManyToMany,
  JoinTable,
  CreateDateColumn,
  UpdateDateColumn,
  Relation,
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

  @ManyToOne(() => Owner, (owner) => owner.books)
  @JoinColumn({ name: "owner_id" })
  owner!: Relation<Owner>

  @ManyToOne(() => Author, (author) => author.books)
  @JoinColumn({ name: "author_id" })
  author!: Relation<Author>

  @ManyToMany(() => Genre, (genre) => genre.books)
  @JoinTable()
  genres!: Relation<Genre>[]
}
