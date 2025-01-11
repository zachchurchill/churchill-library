import React from "react";

type HeadingProps = {
  children: React.ReactNode;
  className?: string;
};

const Heading = ({ children, className = "" }: HeadingProps) => {
  const classNames = `text-2xl font-bold leading-tight tracking-tight text-slate-800 ${className}`.trimEnd();
  return <h1 className={classNames}>{children}</h1>;
};

export default Heading;
