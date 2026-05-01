unit Core.Exceptions;

interface

uses
  System.SysUtils;

type
  EAppException        = class(Exception);
  EConnectionException = class(EAppException);
  ERepositoryException = class(EAppException);
  EValidationException = class(EAppException);
  EBusinessException   = class(EAppException);

implementation

end.
