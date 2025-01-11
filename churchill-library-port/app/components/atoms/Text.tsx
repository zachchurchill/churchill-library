import React from "react";

type TextProps = {
  children: React.ReactNode;
  className?: string;
};

const Text = ({ children, className = "" }: TextProps) => {
  const classNames = `text-base leading-8 text-slate-600 ${className}`.trimEnd();
  return <p className={classNames}>{children}</p>;
};

export default Text;
