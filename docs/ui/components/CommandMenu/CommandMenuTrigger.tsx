import { css } from '@emotion/react';
import { breakpoints, iconSize, SearchIcon, shadows, spacing, theme } from '@expo/styleguide';
import { Dispatch, SetStateAction, useEffect, useState } from 'react';

import { isAppleDevice } from './utils';

import { Button } from '~/ui/components/Button';
import { CALLOUT, KBD } from '~/ui/components/Text';

type Props = {
  setOpen: Dispatch<SetStateAction<boolean>>;
};

export const CommandMenuTrigger = ({ setOpen }: Props) => {
  const [isMac, setIsMac] = useState<boolean | null>(null);

  useEffect(() => {
    setIsMac(typeof navigator !== 'undefined' && isAppleDevice());
  }, []);

  useEffect(() => {
    if (isMac !== null) {
      const keyDownListener = (e: KeyboardEvent) => {
        if (e.key === 'k' && (isMac ? e.metaKey : e.ctrlKey)) {
          e.preventDefault();
          setOpen(open => !open);
        }
      };
      document.addEventListener('keydown', keyDownListener, false);
      return () => document.removeEventListener('keydown', keyDownListener);
    }
  }, [isMac]);

  return (
    <Button theme="ghost" css={buttonStyle} onClick={() => setOpen(true)}>
      <SearchIcon size={iconSize.small} />
      <CALLOUT css={[labelStyle, hideOnMobileStyle]}>Search</CALLOUT>
      {isMac !== null && (
        <div css={[keysWrapperStyle, hideOnMobileStyle]}>
          <KBD>{isMac ? '⌘' : 'Ctrl'}</KBD> <KBD>K</KBD>
        </div>
      )}
    </Button>
  );
};

const buttonStyle = css({
  width: '20vw',
  minWidth: 240,
  maxWidth: 320,
  padding: `0 ${spacing[3]}px`,
  borderColor: theme.border.default,
  boxShadow: shadows.input,
  marginRight: spacing[3],

  '&:focus': {
    boxShadow: shadows.button,
  },

  '> div': {
    width: '100%',
    gap: spacing[2.5],
  },

  kbd: {
    height: 20,
    lineHeight: '19px',
  },

  [`@media screen and (max-width: ${breakpoints.medium}px)`]: {
    minWidth: 42,
    width: 42,
    marginRight: 0,
  },
});

const labelStyle = css({
  color: theme.icon.secondary,
});

const keysWrapperStyle = css({
  marginLeft: 'auto',
});

const hideOnMobileStyle = css({
  [`@media screen and (max-width: ${breakpoints.medium}px)`]: {
    display: 'none',
  },
});
