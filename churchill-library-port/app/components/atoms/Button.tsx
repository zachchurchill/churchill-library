type ButtonProps = {
  label: string;
  disabled?: boolean;
  className?: string;
};

const Button = ({ label, disabled = false, className = "" }: ButtonProps) => {
  const disabledClasses = disabled
    ? "disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-green-800"
    : "";
  const classes = [
    "rounded-md",
    "text-xs",
    "md:text-sm",
    "font-semibold",
    "text-white",
    "shadow-sm",
    "bg-green-800",
    "hover:bg-green-700",
    "cursor-pointer",
    disabledClasses,
    className,
  ].join(" ").trimEnd();

  return (
    <button className={classes} disabled={disabled}>{label}</button>
  );
};

export default Button;
