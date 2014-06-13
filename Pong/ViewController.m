#import "ViewController.h"
#import "BallView.h"
#import "PaddleView.h"
#import "BlockView.h"

@interface ViewController () <UICollisionBehaviorDelegate>
@property (weak, nonatomic) IBOutlet PaddleView *paddleView;
@property (weak, nonatomic) IBOutlet BallView *ballView;
@property (weak, nonatomic) IBOutlet UIView *subViewBlocks;
@property UIDynamicAnimator *dynamicAnimator;
@property UIPushBehavior *pushBehavior;
@property UICollisionBehavior *collisionBehavior;
@property UIDynamicItemBehavior *ballDynamicBehavior;
@property UIDynamicItemBehavior *paddleDynamicBehavior;
@property UIDynamicItemBehavior *blockDynamicBehavior;
@property NSArray *blocks;
@end



@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    //Put all the blocks together easily through subview//
    self.blocks = [[NSArray alloc] initWithArray:self.subViewBlocks.subviews];
    //Set the Dynamic Animator//
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    //For Collision init//
    NSMutableArray *all = [NSMutableArray arrayWithArray:self.blocks];
        [all addObject:self.paddleView];
        [all addObject:self.ballView];


    //Push//
        self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.ballView] mode:UIPushBehaviorModeInstantaneous];
        self.pushBehavior.pushDirection = CGVectorMake(1, 0.8);
        self.pushBehavior.active = YES;
        self.pushBehavior.magnitude = 1;
    [self.dynamicAnimator addBehavior:self.pushBehavior];

    //Collison//
        self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:all];
        self.collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
        self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
        self.collisionBehavior.collisionDelegate = self;
    [self.dynamicAnimator addBehavior:self.collisionBehavior];

    //Ball//
        self.ballDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.ballView]];
        self.ballDynamicBehavior.allowsRotation = NO;
        self.ballDynamicBehavior.elasticity = 1.0;
        self.ballDynamicBehavior.friction = 0.0;
        self.ballDynamicBehavior.resistance = 0.0;
    [self.dynamicAnimator addBehavior:self.ballDynamicBehavior];

    //Block//
        self.blockDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:self.blocks];
        self.blockDynamicBehavior.density = RAND_MAX;
        self.blockDynamicBehavior.allowsRotation = NO;
    [self.dynamicAnimator addBehavior:self.blockDynamicBehavior];

    //Paddle
        self.paddleDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.paddleView]];
        self.paddleDynamicBehavior.allowsRotation = NO;
        self.paddleDynamicBehavior.density = RAND_MAX;
    [self.dynamicAnimator addBehavior:self.paddleDynamicBehavior];


}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if (p.y > self.view.frame.size.height - 1) {
    self.ballView.center = CGPointMake(150, 400);
    [self.dynamicAnimator updateItemUsingCurrentState:self.ballView];

        for (BlockView *block in self.blocks) {
            [self.collisionBehavior addItem:block];
            block.hidden = NO;
        }
    }
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    //If ball hits block//
    for (BlockView *block in self.blocks) {
        if (item2 == block && item1 == self.ballView) {
            block.hidden = YES;
            [self.collisionBehavior removeItem:block];
        }
        //If all blocks are gone//
        if (self.collisionBehavior.items.count == 2) {
            for (BlockView *block in self.blocks) {
                [self.collisionBehavior addItem:block];
                block.hidden = NO;
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }

}


#pragma - Helper

- (void)viewWillAppear:(BOOL)animated
{
    for (BlockView *block in self.blocks) {
        [self.collisionBehavior addItem:block];
        block.hidden = NO;
    }
}
- (IBAction)ondrag:(UIPanGestureRecognizer *)sender
{
    self.paddleView.center = CGPointMake([sender locationInView:self.view].x, self.paddleView.center.y);
    [self.dynamicAnimator updateItemUsingCurrentState:self.paddleView];
}

-(IBAction)unwind:(UIStoryboardSegue *)sender {
}

@end
