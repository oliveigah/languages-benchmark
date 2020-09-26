const useCase = ({ counter }) => {
  let result = 0;
  for(let i = 0; i <= counter; i++) {
    result = i
  }
  return result
};

module.exports = useCase;
