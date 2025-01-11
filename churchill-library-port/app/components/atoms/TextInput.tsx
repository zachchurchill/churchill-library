type TextInputProps = {
  inputId: string;
  placeholder?: string;
  className?: string;
};

const TextInput = ({ inputId, placeholder = "Placeholder", className = "" }: TextInputProps) => {
  const classes = `rounded-full border border-solid border-slate-200 focus:border-transparent focus:shadow-none ${className}`.trimEnd();
  return (
    <input
      id={inputId}
      type="text"
      placeholder={placeholder}
      className={classes}
    />
  );
};

export default TextInput;
