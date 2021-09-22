import { constants, resources } from 'c/igConstants';
import { util as utilGenerics } from 'c/igUtilityGeneric';
import { util as utilSpecifics } from 'c/igUtilitySpecific';

const util = Object.assign({}, utilGenerics, utilSpecifics);

export { util, resources, constants };