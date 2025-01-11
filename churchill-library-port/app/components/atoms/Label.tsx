type LabelProps = {
  inputId: string;
  label: string;
  className?: string;
};

const Label = ({ inputId, label, className = "" }: LabelProps) => {
  const classes = `block text-xs md:text-sm font-medium leading-6 text-gray-900 ${className}`.trimEnd();
  return <label htmlFor={inputId} className={classes}>{label}</label>
};

export default Label;
