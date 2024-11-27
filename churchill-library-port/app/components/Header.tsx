import React from "react";
import Image from "next/image";
import Link from "next/link";

interface NavLinkProps {
  linkText: string;
  linkTo: string;
  isPrimary?: boolean;
}

const NavLink = ({ linkText, linkTo, isPrimary = true }: NavLinkProps) => (
  <Link
    href={linkTo}
    className={`text-sm font-semibold leading-6 ${isPrimary ? "text-gray-700" : "text-gray-400"} hover:text-green-900`}
  >
  {linkText}
  </Link>
);

const Logo = () => (
  <Link
    href="/"
    className="-m-1.5 p-1.5"
  >
    <span className="sr-only">Churchill Library</span>
    <Image
      src="/logo.svg"
      className="h-16 w-auto"
      height={20}
      width={20}
      alt="Squirrel sitting on book logo"
    />
  </Link>
);

interface HeaderProps {
  loggedIn?: boolean;
}

export default function Header({ loggedIn = false }: HeaderProps) {
  return (
    <header className="mx-auto flex max-w-7xl items-center justify-between p-6 lg:px-8">
      <div className="flex lg:flex-1">
        <Logo />
      </div>
      <nav className="flex flex-1 gap-x-4 md:gap-x-8 lg:gap-x-12 justify-end" aria-label="Global">
        <NavLink linkTo="/" linkText="Home" />
        <NavLink linkTo="/" linkText="Books" />
        {
          loggedIn
          ? <NavLink linkTo="/" linkText="Logout" isPrimary={false} />
          : <NavLink linkTo="/" linkText="Admin" isPrimary={false} />
        }
      </nav>
    </header>
  );
}
